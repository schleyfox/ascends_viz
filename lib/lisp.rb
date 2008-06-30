# This file contains utility functions that remind me of lisp.
# Currently it will mostly be car and cdr but we will see

def cdr(ary)
  ary[1...ary.size]
end

def car(ary)
  ary.first
end
