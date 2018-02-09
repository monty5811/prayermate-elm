#!/usr/bin/env python
import json
import os

PATHS = [
    'src/test_data.json',
    'src/test_data_ios.json',
]

file_header = 'module Fixtures exposing (..)'


def load_data(p):
    name = os.path.basename(p).replace('.json', '')
    with open(p, 'rb') as f:
        data = f.read()
    return name, json.dumps(json.loads(data))


def add_fixture(file_content, fixture):
    name, data = fixture
    data = data.encode("unicode_escape").decode("utf-8")
    return f'{file_content}\n\n\n{name} : String\n{name} =\n    """{data}"""'


def generate():
    fixtures = [load_data(p) for p in PATHS]
    file_content = file_header
    for fixture in fixtures:
        file_content = add_fixture(file_content, fixture)

    with open('tests/Fixtures.elm', 'w') as f:
        f.write(file_content)


if __name__ == '__main__':
    generate()
