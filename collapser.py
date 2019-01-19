from misc import ManoCollapserError
from objs import *


NAMES_COUNT = 0


def genId():
  global NAMES_COUNT
  NAMES_COUNT += 1
  return 'q%05d' % NAMES_COUNT


def collapse_program(functionset):
  global NAMES_COUNT

  if not (isinstance(functionset, dict)):
    raise ManoCollapserError('Input program is not a dictionary of functions.')

  NAMES_COUNT = 0

  # Construct lookup table.
  global_lookup = {'main': 'main', 'null': 'null'}
  for funcname in functionset:
    if funcname != 'main':
      if functionset[funcname].extern:
        global_lookup[funcname] = funcname
      else:
        global_lookup[funcname] = genId() + funcname
  print(global_lookup)
  for func in list(functionset.values()):
    lookup = {}
    lookup.update(global_lookup)

    varnames = list(func.vars.keys())
    for varname in varnames:
      lookup[varname] = genId() + varname
      func.vars[lookup[varname]] = func.vars[varname]
      if varname in func.consts:
          func.consts[lookup[varname]] = func.consts[varname]
          del func.consts[varname]
      del func.vars[varname]

    for i in range(len(func.params)):
      func.params[i] = lookup[func.params[i]]

    for line in func.code:
      attrs = ['label', 'condition', 'target', 'index', 'name', 'arg']

      for attr in attrs:
        if hasattr(line, attr) and getattr(line, attr):
          name = getattr(line, attr)

          if name not in lookup:
            lookup[name] = genId() + name

          setattr(line, attr, lookup[name])

      if hasattr(line, 'expression'):
        exp = line.expression
        attrs = ['function', 'name', 'index', 'operand', 'left', 'right']

        for attr in attrs:
          if hasattr(exp, attr) and getattr(exp, attr):
            name = getattr(exp, attr)

            if name not in lookup:
              lookup[name] = genId() + name

            setattr(exp, attr, lookup[name])

        if hasattr(exp, 'arguments'):
          for i in range(len(exp.arguments)):
            name = exp.arguments[i]

            if name not in lookup:
              lookup[name] = genId() + name

            exp.arguments[i] = lookup[name]

  # Rename functions.
  funcs = list(functionset.keys())
  for funcname in funcs:
    if funcname != 'main':
      functionset[lookup[funcname]] = functionset[funcname]
      del functionset[funcname]

  return functionset
