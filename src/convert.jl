# Main module of the hijri-converter package.
include("ummalqura.jl")
include("helpers.jl")
include("locales.jl")
using .ummalqura
using .helpers
using .locales
using Parameters

@with_kw struct Hijri
	validate::Bool=true
	year::Int64
	month::Int64
	day::Int64
end

@doc    """Construct Hijri object from an ISO formatted Hijri date
        ``YYYY-MM-DD``.

        :param date_string: Hijri date in ISO format ``YYYY-MM-DD``.
        :type date_string: str
        :rtype: Hijri
        """
function fromisoformat(date_string::String)
        year = parse(Int, date_string[1:4])
        month = parse(Int, date_string[6:7])
        day = parse(Int, date_string[9:10])
        return Hijri(true, year, month, day) #TODO: true should be implicit
end


@doc    """Construct Hijri object from today's date.

        :rtype: Hijri
        """
function today()
        return Gregorian.today().to_hijri()
end

@doc     """Return year as an integer."""
function year(date::Hijri)
        return date.year
end

@doc     """Return month as an integer."""
function month(date::Hijri)
        return date.month
end

@doc     """Return day as an integer."""
function day(date::Hijri)
        return date.day
end

@doc     """Return date as a tuple of (year, month, day)."""
function datetuple(date::Hijri)
        return date.year, date.month, date.day
end

@doc     """Return date in ISO format i.e. ``YYYY-MM-DD``."""
function isoformat(date::Hijri)
        return string(date.year, "-", date.month, "-", date.day)
end


@doc	"""
        Return date in day-month-year format (``DD/MM/YYYY`` by default).

       :param separator: String that separates the day, month, and year values.
        :type separator: str
        :param padding: Whether to add a leading zero as a padding character to fill
            day and month values when less than 10.
        :type padding: bool
	"""
function dmyformat(date::Hijri, separator::String = "/", padding::Bool = true)
        day = padding ? lpad(date.day, 2, "0") : date.day
        month = padding ? lpad(date.month, 2, "0") : date.month
        return string(day, separator, month, separator, date.year)
end

@doc     """Return number of days in month."""
function month_length(date::Hijri)
        month_starts = ummalqura.MONTH_STARTS
        index = _month_index(date)
        length = month_starts[index + 1] - month_starts[index]
        return length
end

@doc     """Return month name.

        :param language: Language tag for localized month name. Full locale name can
            be used, e.g. ``en-US`` or ``en_US.UTF-8``. Supported languages are
            ``en``, ``ar`` and ``bn``.
        :type language: str
        """
function month_name(date::Hijri, language::String = "en")
        return locales.month_name(locales.get_locale(language), date.month)
end

@doc    """Return day of week, where Monday is 0 and Sunday is 6."""
function weekday(date::Hijri)
        jdn = to_julian(date)
        return Int(jdn % 7)
end

@doc    """Return day of week, where Monday is 1 and Sunday is 7."""
function isoweekday(date::Hijri)
        jdn = to_julian(date)
        return Int(jdn % 7) + 1
end

@doc    """Return day name.

        :param language: Language tag for localized day name. Full locale name can
            be used, e.g. ``en-US`` or ``en_US.UTF-8``. Supported languages are
            ``en``, ``ar`` and ``bn``.
        :type language: str
        """
function day_name(date::Hijri, language::String = "en")

        return locales.day_name(locales.get_locale(language), isoweekday(date))
end

@doc    """Return calendar era notation.

        :param language: Language tag for localized notation. Full locale name can
            be used, e.g. ``en-US`` or ``en_US.UTF-8``. Supported languages are
            ``en``, ``ar`` and ``bn``.
        :type language: str
        """
function notation(language::String = "en")

        return locales.get_locale(language).notation
end

@doc    """Return corresponding Julian day number (JDN)."""
function to_julian(date::Hijri)
        month_starts = ummalqura.MONTH_STARTS
        index = _month_index(date)
        rjd = month_starts[index] + date.day - 1
        jdn = helpers.rjd_to_jdn(rjd)
        return jdn
end

@doc    """Return Gregorian object for the corresponding Hijri date.

        :rtype: Gregorian
        """
function to_gregorian(date::Hijri)
        jdn = self.to_julian()
        n = helpers.jdn_to_ordinal(jdn)
        return Gregorian.fromordinal(n)
end        

@doc    """Check date values if within valid range."""
function _check_date_(date::Hijri)
        # check year
        min_year, max_year = [d[1] for d in ummalqura.HIJRI_RANGE]
        if min_year > date.year ||  date.year > max_year
            throw(error("date out of range")) # replace with overflow error
        end
        # check month
        if 1 > date.month || date.month > 12
            throw(ValueError("month must be in 1..12"))
        end
        # check day
        month_len = month_length(date)
        if 1 > date.day || date.day > month_len
            throw(ValueError(string("day must be in 1..", month_len, " for month")))
        end
end

@doc    """Return month’s index in ummalqura month starts""" #add arrow???
function _month_index(date::Hijri)
        prior_months = ((date.year - 1) * 12) + date.month - 1
        index = prior_months - ummalqura.HIJRI_OFFSET
        return index
end
