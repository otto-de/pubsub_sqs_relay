import json


def info(msg, *args):
    if len(args) > 0:
        print("[lambda] " + str(msg) + "|" + str(args))
    else:
        print("[lambda] " + str(msg))


def read_json_as_dict(json_file):
    with open('%s' % json_file) as json_file:
        content = json.load(json_file)
    return content


def read_file_as_string(file):
    with open('%s' % file) as json_file:
        content = json_file.read()
    return content
