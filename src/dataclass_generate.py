#!/usr/bin/env python3
import json
import argparse
from collections import namedtuple

DataClass = namedtuple('DataClass', 'name inherit members')
TypedName = namedtuple(
    'TypedName',
    'type variant parameter_type default_value name'
)


bind_template = '''
static void _bind_methods() {{
    ClassDB::bind_static_method(
        "{class_name}",
        D_METHOD("create",
{property_names}
        ),
        &{class_name}::create
    );
    {property_binds}
}}
'''


bind_property_template = '''
ClassDB::bind_method(
    D_METHOD("get_{property_name}"),
    &{class_name}::get_{property_name}
);
ClassDB::bind_method(
    D_METHOD("set_{property_name}"),
    &{class_name}::set_{property_name}
);
ADD_PROPERTY(
    PropertyInfo({property_variant}, "{property_name}"),
    "set_{property_name}",
    "get_{property_name}"
);
'''

constructor_template = '''
{class_name}() {{
{property_defaults}
}}
{class_name}(
{property_params}
) {{
{property_assigns}
}}
~{class_name}() {{}}

static {class_name}* create(
{property_params}
) {{
    return memnew({class_name}(
{param_names}
    ));
}}
'''

setter_template = '''
void set_{property_name}({property_parameter_type} new_{property_name}) {{
    {property_name} = new_{property_name};
}}
{property_return_type} get_{property_name}() const {{
    return {property_name};
}}
'''

class_template = '''
class {class_name} : public {inherit} {{
    GDCLASS({class_name}, {inherit})

protected:
{binds}

public:
{constructors}

{members}

{setters}
}};
'''


type_map = {
    'Bytes': [
        'PackedByteArray',
        'Variant::PACKED_BYTE_ARRAY',
        'const PackedByteArray &',
        'PackedByteArray()'
    ],
    'bool': [
        'bool',
        'Variant::BOOL',
        'bool',
        'false'
    ]
}


def get_type(t):
    return type_map[t]


def indent_n(t, level, indentation='    '):
    return '\n'.join([
        indentation * level + s
        for s in t.strip().split('\n')
    ])


def indent(a, b=None, indentation='    '):
    if b is None:
        return indent_n(a, 1, indentation)
    return indent_n(b, a, indentation)


def transform(definitions):
    return [
        DataClass(
            class_name,
            'GDSodiumType',
            [TypedName(*get_type(type), name) for name, type in members.items()]
        ) for class_name, members in definitions.items()
    ]


def generate_binds(definition):
    return bind_template.format(
        class_name=definition.name,
        property_names=indent(3, ',\n'.join([
            f'"{t.name}"' for t in definition.members
        ])),
        property_binds='\n\n'.join([
            indent(bind_property_template.format(
                class_name=definition.name,
                property_name=prop.name,
                property_variant=prop.variant
            )) for prop in definition.members
        ])
    )


def generate_class(definition):
    return class_template.format(
        class_name=definition.name,
        inherit=definition.inherit,
        members=indent('\n'.join([
            f'{t.type} {t.name};' for t in definition.members
        ])),
        binds=indent(generate_binds(definition)),
        constructors=indent(constructor_template.format(
            class_name=definition.name,
            param_names=indent(2, ',\n'.join([
                f'new_{t.name}' for t in definition.members
            ])),
            property_params=indent(',\n'.join([
                f'{t.parameter_type} new_{t.name}' for t in definition.members
            ])),
            property_defaults=indent('\n'.join([
                f'{t.name} = {t.default_value};'
                for t in definition.members
            ])),
            property_assigns=indent('\n'.join([
                f'this->{t.name} = new_{t.name};'
                for t in definition.members
            ])),
        )),
        setters=indent(''.join([
            setter_template.format(
                property_name=prop.name,
                property_parameter_type=prop.parameter_type,
                property_return_type=prop.type
            ) for prop in definition.members
        ]))
    )


def generate(definitions):
    return '\n'.join(generate_class(dc) for dc in definitions)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('definitions')
    args = parser.parse_args()

    with open(args.definitions) as f:
        definitions = json.load(f)

    print(generate(transform(definitions)))


if __name__ == '__main__':
    main()
