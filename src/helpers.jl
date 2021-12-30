module helpers
"""Helper methods for Hijri conversion."""

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
end
