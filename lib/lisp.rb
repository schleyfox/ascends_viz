# This file contains utility functions that remind me of lisp.
# Currently it will mostly be car and cdr but we will see

def cdr(ary)
  ary[1...ary.size]
end

def car(ary)
  ary.first
end

# This really doesn't fucking go here, fuck it
def within_tolerance?(tol, val1, val2)
  return nil if(tol > 1 or tol < 0)
  upper_bound = (1+tol) * val1
  lower_bound = (1+tol) * val1
  return val2 > lower_bound and val2 < upper_bound
end 
