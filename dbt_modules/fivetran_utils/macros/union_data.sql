{% macro union_data(table_identifier, database_variable, schema_variable, default_database, default_schema, default_variable) -%}

{{ adapter.dispatch('union_data', 'fivetran_utils') (table_identifier, database_variable, schema_variable, default_database, default_schema, default_variable) }}

{%- endmacro %}

{% macro default__union_data(table_identifier, database_variable, schema_variable, default_database, default_schema, default_variable) %}

{% if var('union_schemas', none) %}

    {% set relations = [] %}

    {% if var('union_schemas') is string %}
    {% set trimmed = var('union_schemas')|trim('[')|trim(']')|trim('(')|trim(')') %}
    {% set schemas = trimmed.split(',')|map('trim'," ")|map('trim','"')|map('trim',"'") %}
    {% else %}
    {% set schemas = var('union_schemas') %}
    {% endif %}

    {% for schema in schemas %}

    {% set relation=adapter.get_relation(
        database=var(database_variable, default_database),
        schema=schema,
        identifier=table_identifier
    ) -%}
    
    {% set relation_exists=relation is not none %}

    {% if relation_exists %}

    {% do relations.append(relation) %}
    
    {% endif %}

    {% endfor %}

    {{ dbt_utils.union_relations(relations) }}

{% elif var('union_databases', none) %}

    {% set relations = [] %}

    {% for database in var('union_databases') %}

    {% set relation=adapter.get_relation(
        database=database,
        schema=var(schema_variable, default_schema),
        identifier=table_identifier
    ) -%}

    {% set relation_exists=relation is not none %}

    {% if relation_exists %}

    {% do relations.append(relation) %}
    
    {% endif %}

    {% endfor %}

    {{ dbt_utils.union_relations(relations) }}

{% else %}

    select * 
    from {{ var(default_variable) }}

{% endif %}

{% endmacro %}
