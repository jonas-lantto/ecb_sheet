require 'table_transform'

def cross_currency_sheet(target_currency, currency_date, currency_rates, sheet_name = nil)
  sheet_name = sheet_name || "fxrates #{target_currency} #{currency_date}.xlsx"
  xls = TableTransform::ExcelCreator.new(sheet_name)
  xls.add_tab("FxRates(ECB) #{target_currency} #{currency_date}", currency_rates.table_data_currency2rate(currency_date, target_currency))
  xls.create!
end

def currency_series_sheet(src_currency, target_currency, currency_rates)
  xls = TableTransform::ExcelCreator.new("fxrates #{src_currency}#{target_currency}.xlsx")
  xls.add_tab("FxRates(ECB) #{src_currency}#{target_currency}",  currency_rates.table_data_date2rate(src_currency, target_currency))
  xls.create!
end