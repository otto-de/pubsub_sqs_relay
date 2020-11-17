import inspect


def execute_all_tests_in_current_file(mod):
    all_functions = inspect.getmembers(mod, inspect.isfunction)
    for key, value in all_functions:
        if key.startswith('test_'):
            print(">>>>>>>> executing test [" + key + "]")
            value()
