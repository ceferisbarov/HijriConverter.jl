include("unit/test_core.jl")
include("unit/test_helpers.jl")
include("unit/test_locales.jl")
using .test_core
using .test_helpers
using .test_locales

# TEST CORE
test_core.test_equality()

test_core.test_ordering()

test_core.test_fromisoformat()

test_core.test_today()

test_core.test_year()

test_core.test_month()

test_core.test_day()

test_core.test_datetuple()

test_core.test_isoformat()

test_core.test_dmyformat()

test_core.test_month_length()

test_core.test_month_name()

test_core.test_weekday()

test_core.test_iso_weekday()

test_core.test_day_name()

test_core.test_notation()

test_core.test_to_julian()

test_core.test_to_gregorian()

test_core.test_month_index()

# TEST HELPERS
test_helpers.test_helper_functions()

# TEST LOCALES
test_locales.test_locale_data_structure()

test_locales.test_locale_map()
