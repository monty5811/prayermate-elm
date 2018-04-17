#!/usr/bin/env python
import json
import os

PATHS = [
    'src/test_data.json',
    'src/test_data_ios.json',
    'src/test_schedules.json',
]

file_header = 'module Fixtures exposing (..)'


def make_csv_string(data):
    csv_string = ''
    for cat in data['Categories']:
        cat_name = cat['name']
        for sub in cat['subjects']:
            sub_name = sub['name']
            for card in sub['cards']:
                try:
                    content = card['text']
                except KeyError:
                    content =''
                csv_string += f'"{cat_name}","{sub_name}","{content}"\n'

    return csv_string


def load_data(p):
    name = os.path.basename(p).replace('.json', '')
    with open(p, 'rb') as f:
        data = f.read()

    json_data = json.loads(data)
    json_string = json.dumps(json_data)

    csv_string = make_csv_string(json_data)
    return name, json_string, csv_string


def add_fixture(file_content, fixture):
    name, json_string, csv_string = fixture

    json_string = json_string.encode("unicode_escape").decode("utf-8")
    json_fixture = f'{name} : String\n{name} =\n    """{json_string}"""'

    csv_string = csv_string.encode("unicode_escape").decode("utf-8")
    csv_fixture = f'{name}_csv: String\n{name}_csv =\n    """{csv_string}"""'

    return f'{file_content}\n\n\n{json_fixture}\n\n\n{csv_fixture}'


def generate():
    fixtures = [load_data(p) for p in PATHS]
    file_content = file_header
    for fixture in fixtures:
        file_content = add_fixture(file_content, fixture)

    with open('tests/Fixtures.elm', 'w') as f:
        f.write(file_content)


if __name__ == '__main__':
    generate()
