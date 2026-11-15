use crate::rust::to_rust_upper_camel_case;
use crate::{InterfaceGenerator, rust::RustGenerator, rust::TypeMode};
use std::fmt::Write as _;
use wit_parser::{Type, TypeDefKind, TypeId};

impl InterfaceGenerator<'_> {
    fn has_host_input(&self, ty: &Type) -> bool {
        if self.direct_borrowed_type(ty).is_some() {
            return true;
        }
        let Type::Id(id) = ty else { return false };
        match &self.resolve.types[*id].kind {
            TypeDefKind::Record(r) => r.fields.iter().any(|f| self.has_host_input(&f.ty)),
            TypeDefKind::Variant(v) => v
                .cases
                .iter()
                .any(|c| c.ty.is_some_and(|t| self.has_host_input(&t))),
            TypeDefKind::Tuple(t) => t.types.iter().any(|t| self.has_host_input(t)),
            TypeDefKind::Type(t)
            | TypeDefKind::Option(t)
            | TypeDefKind::List(t)
            | TypeDefKind::FixedLengthList(t, _) => self.has_host_input(t),
            TypeDefKind::Result(r) => [r.ok, r.err]
                .into_iter()
                .flatten()
                .any(|t| self.has_host_input(&t)),
            _ => false,
        }
    }

    fn host_input_name(&self, id: TypeId, cursor: bool) -> String {
        let ty = &self.resolve.types[id];
        let suffix = if cursor {
            "HostInputCursor"
        } else {
            "HostInput"
        };
        self.type_name_in_interface(
            ty.owner,
            &format!(
                "{}{suffix}",
                to_rust_upper_camel_case(ty.name.as_ref().unwrap())
            ),
        )
    }

    pub(super) fn host_input_ty(&self, ty: &Type, cursor: bool, lifetime: &str) -> String {
        let wt = self.generator.wasmtime_path();
        if let Some(direct) = self.direct_borrowed_type(ty) {
            return match (direct, cursor) {
                (Type::String, true) => format!("{wt}::component::WasmStr"),
                (Type::String, false) => {
                    format!("{wt}::component::__internal::Cow<{lifetime}, str>")
                }
                (_, true) => format!("{wt}::component::WasmList<u8>"),
                (_, false) => format!("&{lifetime} [u8]"),
            };
        }
        if !self.has_host_input(ty) {
            return self.ty(ty, TypeMode::Owned);
        }
        let Type::Id(id) = ty else { unreachable!() };
        let nested = |t: &Type| self.host_input_ty(t, cursor, lifetime);
        let optional = |t: Option<Type>| t.map_or_else(|| "()".into(), |t| nested(&t));
        match &self.resolve.types[*id].kind {
            TypeDefKind::Record(_) | TypeDefKind::Variant(_) => {
                let name = self.host_input_name(*id, cursor);
                if cursor {
                    name
                } else {
                    format!("{name}<{lifetime}>")
                }
            }
            TypeDefKind::Type(t) => nested(t),
            TypeDefKind::Option(t) => format!("Option<{}>", nested(t)),
            TypeDefKind::Result(r) => format!("Result<{}, {}>", optional(r.ok), optional(r.err)),
            TypeDefKind::Tuple(t) => format!(
                "({},)",
                t.types.iter().map(nested).collect::<Vec<_>>().join(",")
            ),
            TypeDefKind::List(t) => format!("{wt}::component::__internal::Vec<{}>", nested(t)),
            TypeDefKind::FixedLengthList(t, n) => format!("[{}; {n}]", nested(t)),
            _ => unreachable!(),
        }
    }

    pub(super) fn host_input_value(&self, ty: &Type, value: &str) -> String {
        if let Some(direct) = self.direct_borrowed_type(ty) {
            return if direct == Type::String {
                format!("{value}.to_str_in(_memory)?")
            } else {
                format!("{value}.as_le_slice_in(_memory)")
            };
        }
        if !self.has_host_input(ty) {
            return value.into();
        }
        let Type::Id(id) = ty else { unreachable!() };
        let wt = self.generator.wasmtime_path();
        match &self.resolve.types[*id].kind {
            TypeDefKind::Record(_) | TypeDefKind::Variant(_) => {
                format!("{value}.into_host_input(_memory)?")
            }
            TypeDefKind::Type(t) => self.host_input_value(t, value),
            TypeDefKind::Option(t) => format!(
                "match {value} {{ Some(value) => Some({}), None => None }}",
                self.host_input_value(t, "value")
            ),
            TypeDefKind::Result(r) => {
                let convert = |t: Option<Type>| {
                    t.map_or_else(|| "value".into(), |t| self.host_input_value(&t, "value"))
                };
                format!(
                    "match {value} {{ Ok(value) => Ok({}), Err(value) => Err({}) }}",
                    convert(r.ok),
                    convert(r.err)
                )
            }
            TypeDefKind::Tuple(t) => {
                let names: Vec<_> = (0..t.types.len()).map(|i| format!("field{i}")).collect();
                let converted = t
                    .types
                    .iter()
                    .zip(&names)
                    .map(|(t, n)| self.host_input_value(t, n))
                    .collect::<Vec<_>>()
                    .join(",");
                format!("{{ let ({},) = {value}; ({converted},) }}", names.join(","))
            }
            TypeDefKind::List(t) => format!(
                "{value}.into_iter().map(|value| -> {wt}::Result<_> {{ Ok({}) }}).collect::<{wt}::Result<{wt}::component::__internal::Vec<_>>>()?",
                self.host_input_value(t, "value")
            ),
            TypeDefKind::FixedLengthList(t, n) => {
                let names: Vec<_> = (0..*n).map(|i| format!("field{i}")).collect();
                let converted = names
                    .iter()
                    .map(|name| self.host_input_value(t, name))
                    .collect::<Vec<_>>()
                    .join(",");
                format!("{{ let [{}] = {value}; [{converted}] }}", names.join(","))
            }
            _ => unreachable!(),
        }
    }

    pub(super) fn define_host_input(&mut self, id: TypeId) {
        if !self.has_host_input(&Type::Id(id)) {
            return;
        }
        let ty = &self.resolve.types[id];
        if !matches!(ty.kind, TypeDefKind::Record(_) | TypeDefKind::Variant(_)) {
            return;
        }
        let base = to_rust_upper_camel_case(ty.name.as_ref().unwrap());
        let wt = self.generator.wasmtime_path();
        for cursor in [true, false] {
            let name = format!(
                "{base}{}",
                if cursor {
                    "HostInputCursor"
                } else {
                    "HostInput<'a>"
                }
            );
            if cursor {
                uwriteln!(
                    self.src,
                    "#[derive({wt}::component::ComponentType, {wt}::component::Lift)]"
                );
                if let Some(path) = &self.generator.opts.wasmtime_crate {
                    uwriteln!(self.src, "#[component(wasmtime_crate = {path})]");
                }
            }
            if !cursor {
                uwriteln!(self.src, "#[derive(Debug)]");
            }
            match &ty.kind {
                TypeDefKind::Record(record) => {
                    if cursor {
                        uwriteln!(self.src, "#[component(record)]");
                    }
                    uwriteln!(self.src, "pub struct {name} {{");
                    for field in &record.fields {
                        if cursor {
                            uwriteln!(self.src, "#[component(name = {:?})]", field.name);
                        }
                        let name = crate::rust::to_rust_ident(&field.name);
                        let ty = self.host_input_ty(&field.ty, cursor, "'a");
                        uwriteln!(self.src, "pub {name}: {ty},");
                    }
                }
                TypeDefKind::Variant(variant) => {
                    if cursor {
                        uwriteln!(self.src, "#[component(variant)]");
                    }
                    uwriteln!(self.src, "pub enum {name} {{");
                    for case in &variant.cases {
                        if cursor {
                            uwriteln!(self.src, "#[component(name = {:?})]", case.name);
                        }
                        let name = to_rust_upper_camel_case(&case.name);
                        let payload = case.ty.map_or_else(String::new, |t| {
                            format!("({})", self.host_input_ty(&t, cursor, "'a"))
                        });
                        uwriteln!(self.src, "{name}{payload},");
                    }
                }
                _ => unreachable!(),
            }
            uwriteln!(self.src, "}}");
        }
        uwriteln!(
            self.src,
            "impl {base}HostInputCursor {{ fn into_host_input<'a>(self, _memory: {wt}::component::HostMemory<'a>) -> {wt}::Result<{base}HostInput<'a>> {{ Ok("
        );
        match &ty.kind {
            TypeDefKind::Record(record) => {
                uwriteln!(self.src, "{base}HostInput {{");
                for field in &record.fields {
                    let name = crate::rust::to_rust_ident(&field.name);
                    let value = self.host_input_value(&field.ty, &format!("self.{name}"));
                    uwriteln!(self.src, "{name}: {value},");
                }
                uwriteln!(self.src, "}}");
            }
            TypeDefKind::Variant(variant) => {
                uwriteln!(self.src, "match self {{");
                for case in &variant.cases {
                    let name = to_rust_upper_camel_case(&case.name);
                    if let Some(t) = case.ty {
                        let value = self.host_input_value(&t, "value");
                        uwriteln!(
                            self.src,
                            "Self::{name}(value) => {base}HostInput::{name}({value}),"
                        );
                    } else {
                        uwriteln!(self.src, "Self::{name} => {base}HostInput::{name},");
                    }
                }
                uwriteln!(self.src, "}}");
            }
            _ => unreachable!(),
        }
        uwriteln!(self.src, ") }} }}");
    }
}

impl InterfaceGenerator<'_> {
    pub(super) fn host_prepared_name(func: &wit_parser::Function) -> anyhow::Result<String> {
        let name = crate::rust_function_name(func)?;
        Ok(format!(
            "{}Prepared",
            to_rust_upper_camel_case(name.trim_start_matches("r#"))
        ))
    }

    pub(super) fn host_input_trait(
        &self,
        owner: wit_parser::TypeOwner,
        func: &wit_parser::Function,
    ) -> String {
        match func.kind.resource() {
            Some(id) => format!(
                "Host{}",
                to_rust_upper_camel_case(self.resolve.types[id].name.as_ref().unwrap())
            ),
            None => match owner {
                wit_parser::TypeOwner::World(id) => format!(
                    "{}Imports",
                    to_rust_upper_camel_case(&self.resolve.worlds[id].name)
                ),
                _ => "Host".into(),
            },
        }
    }

    pub(super) fn generate_host_input_prepare(
        &mut self,
        owner: wit_parser::TypeOwner,
        func: &wit_parser::Function,
        flags: crate::FunctionFlags,
    ) -> anyhow::Result<()> {
        let wt = self.generator.wasmtime_path();
        let host_trait = self.host_input_trait(owner, func);
        let name = crate::rust_function_name(func)?;
        let name = name.trim_start_matches("r#");
        if self.named_import_id.is_some() {
            self.src.push_str("{ let id = id.clone(); ");
        }
        uwrite!(
            self.src,
            "move |caller: &mut T, _memory: {wt}::component::HostMemory<'_>, ("
        );
        for i in 0..func.params.len() {
            uwrite!(self.src, "arg{i},");
        }
        self.src.push_str("): (");
        for param in &func.params {
            self.print_import_param(&param.ty, flags, true);
            self.src.push_str(",");
        }
        self.src.push_str(")| {\n");
        for (i, param) in func.params.iter().enumerate() {
            let value = self.host_input_value(&param.ty, &format!("arg{i}"));
            uwriteln!(self.src, "let arg{i} = {value};");
            if self.direct_borrowed_type(&param.ty) == Some(Type::String) {
                uwriteln!(self.src, "let arg{i} = arg{i}.as_ref();");
            }
        }
        if flags.contains(crate::FunctionFlags::TRACING) {
            let fields = func
                .params
                .iter()
                .enumerate()
                .map(|(i, p)| {
                    crate::formatting_for_arg(
                        &crate::rust::to_rust_ident(&p.name),
                        i,
                        p.ty,
                        self.resolve,
                        flags,
                    )
                })
                .collect::<Vec<_>>();
            let fields = fields.join(",");
            if fields.is_empty() {
                uwriteln!(
                    self.src,
                    "tracing::event!(tracing::Level::TRACE, \"prepare\");"
                );
            } else {
                uwriteln!(
                    self.src,
                    "tracing::event!(tracing::Level::TRACE, {fields}, \"prepare\");"
                );
            }
        }
        uwrite!(
            self.src,
            "<D as {host_trait}WithStore<T>>::prepare_{name}(&mut host_getter(caller), "
        );
        if self.named_import_id.is_some() {
            self.src.push_str("id.clone(), ");
        }
        for i in 0..func.params.len() {
            uwrite!(self.src, "arg{i},");
        }
        self.src.push_str(")\n}");
        if self.named_import_id.is_some() {
            self.src.push_str("}");
        }
        Ok(())
    }
}
