module helpers
"""Helper methods for Hijri conversion."""

_DAYS_IN_MONTH = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
_DAYS_BEFORE_MONTH = [-1]
dbm = 0
for dim in _DAYS_IN_MONTH
    global dbm
    append!(_DAYS_BEFORE_MONTH, dbm)
    dbm += dim
end

function _days_before_year(year)
    "year -> number of days before January 1st of year."
    y = year - 1
    return y*365 + y÷4 - y÷100 + y÷400
end

function _days_before_month(year, month)
    "year, month -> number of days in year preceding first day of month."
    @assert 1 <= month && month <= 12 "month must be in 1..12"
    return _DAYS_BEFORE_MONTH[month] + (month > 2 && _is_leap(year))
end
#TODO: The functions above should probably be implemented in stdlib

_DI400Y = _days_before_year(401)    # number of days in 400 years
_DI100Y = _days_before_year(101)    #    "    "   "   " 100   "
_DI4Y   = _days_before_year(5)      #    "    "   "   "   4   "

# A 4-year cycle has an extra leap day over what we'd get from pasting
# together 4 single years.
@assert _DI4Y == 4 * 365 + 1 _DI4Y

# Similarly, a 400-year cycle has an extra leap day over what we'd get from
# pasting together 4 100-year cycles.
@assert _DI400Y == 4 * _DI100Y + 1 _DI400Y

# OTOH, a 100-year cycle has one fewer leap day than we'd get from
# pasting together 25 4-year cycles.
@assert _DI100Y == 25 * _DI4Y - 1 _DI100Y


function bisect_left(a, x, lo = 1, hi = nothing)
    if lo < 1
        throw(BoundsError(a, lo))
    end
    if hi === nothing
        hi = length(a) + 1  # It's not `length(a)`!
    end
    while lo < hi
        mid = (lo + hi) ÷ 2
        a[mid] < x ? lo = mid + 1 : hi = mid
    end
    return lo
end

@doc  """Convert Julian day number (JDN) to date ordinal number.

      :param jdn: Julian day number (JDN).
      :type jdn: int
      """
function jdn_to_ordinal(jdn::Int)

    return jdn - 1721425
end

@doc  """Convert date ordinal number to Julian day number (JDN).

      :param n: Date ordinal number.
      :type n: int
      """
function ordinal_to_jdn(n::Int)

    return n + 1721425
end

@doc  """Return Reduced Julian Day (RJD) number from Julian day number (JDN).

      :param jdn: Julian day number (JDN).
      :type jdn: int
      """
function jdn_to_rjd(jdn::Int)

    return jdn - 2400000
end

@doc  """Return Julian day number (JDN) from Reduced Julian Day (RJD) number.

      :param rjd: Reduced Julian Day (RJD) number.
      :type rjd: int
      """
function rjd_to_jdn(rjd::Int)

    return rjd + 2400000
end

@doc   "year, month, day -> ordinal, considering 01-Jan-0001 as day 1."
function _ymd2ord(year, month, day)
    @assert 1 <= month && month <= 12 "month must be in 1..12"
    dim = _days_in_month(year, month)
    @assert 1 <= day && day <= dim "day must be in 1..%d' % dim"
    return trunc(Int, _days_before_year(year) +
            _days_before_month(year, month) +
            day)
end

function _days_in_month(year, month)
    "year, month -> number of days in that month in that year."
    @assert 1 <= month && month <= 12 month
    if month == 2 && _is_leap(year)
        return 29
    end
    return _DAYS_IN_MONTH[month]
end

function _is_leap(year)
    "year -> 1 if leap year, else 0."
    return year % 4 == 0 && (year % 100 != 0 || year % 400 == 0)
end


@doc   "ordinal -> (year, month, day), considering 01-Jan-0001 as day 1."
function _ord2ymd(n)

    # n is a 1-based index, starting at 1-Jan-1.  The pattern of leap years
    # repeats exactly every 400 years.  The basic strategy is to find the
    # closest 400-year boundary at or before n, then work with the offset
    # from that boundary to n.  Life is much clearer if we subtract 1 from
    # n first -- then the values of n at 400-year boundaries are exactly
    # those divisible by _DI400Y:
    #
    #     D  M   Y            n              n-1
    #     -- --- ----        ----------     ----------------
    #     31 Dec -400        -_DI400Y       -_DI400Y -1
    #      1 Jan -399         -_DI400Y +1   -_DI400Y      400-year boundary
    #     ...
    #     30 Dec  000        -1             -2
    #     31 Dec  000         0             -1
    #      1 Jan  001         1              0            400-year boundary
    #      2 Jan  001         2              1
    #      3 Jan  001         3              2
    #     ...
    #     31 Dec  400         _DI400Y        _DI400Y -1
    #      1 Jan  401         _DI400Y +1     _DI400Y      400-year boundary
    n -= 1
    n400, n = divrem(n, _DI400Y)
    year = n400 * 400 + 1   # ..., -399, 1, 401, ...

    # Now n is the (non-negative) offset, in days, from January 1 of year, to
    # the desired date.  Now compute how many 100-year cycles precede n.
    # Note that it's possible for n100 to equal 4!  In that case 4 full
    # 100-year cycles precede the desired day, which implies the desired
    # day is December 31 at the end of a 400-year cycle.
    n100, n = divrem(n, _DI100Y)

    # Now compute how many 4-year cycles precede it.
    n4, n = divrem(n, _DI4Y)

    # And now how many single years.  Again n1 can be 4, and again meaning
    # that the desired day is December 31 at the end of the 4-year cycle.
    n1, n = divrem(n, 365)

    year += n100 * 100 + n4 * 4 + n1
    if n1 == 4 || n100 == 4
        @assert n == 0
        return year-1, 12, 31
    end
    
    # Now the year is correct, and n is the offset from January 1.  We find
    # the month via an estimate that's either exact or one too large.
    leapyear = n1 == 3 && (n4 != 24 || n100 == 3)
    @assert leapyear == _is_leap(year)
    month = (n + 50) >> 5
    preceding = _DAYS_BEFORE_MONTH[month] + (month > 2 && leapyear)
    if preceding > n  # estimate is too large
        month -= 1
        preceding -= _DAYS_IN_MONTH[month] + (month == 2 && leapyear)
    end
    
    n -= preceding
    @assert 0 <= n && n < _days_in_month(year, month) string("n: ", n, "days in month: ", _days_in_month(year, month))

    # Now the year and month are correct, and n is the offset from the
    # start of that month:  we're done!
    return year, month, n+1
end

end
