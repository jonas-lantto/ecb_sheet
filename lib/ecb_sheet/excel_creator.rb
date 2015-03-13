require 'write_xlsx'

def create_sheet_currency_rate(workbook, base_currency, currency_date, data)
  worksheet = workbook.add_worksheet("FxRates(ECB) #{base_currency} #{currency_date}")
  currency_format = workbook.add_format(:num_format => "0.0000 \"#{base_currency}\"")

  worksheet.add_table(
      0, 0, data.count, 1,
      {
          :data => data,
          :name => 'FxRates',
          :columns => [
              {:header => 'Currency'},
              {:header => currency_date, :format => currency_format},
          ]
      }
  )
  worksheet.set_column(0, 0, 10)
  worksheet.set_column(1, 1, 13)
end



def create_sheet_date_rate(workbook, src_currency, target_currency, data)
  worksheet = workbook.add_worksheet("FxRates(ECB) #{src_currency}#{target_currency}")
  currency_format = workbook.add_format(:num_format => "0.0000 \"#{target_currency}\"")

  worksheet.add_table(
      0, 0, data.count, 1,
      {
          :data => data,
          :columns => [
              {:header => 'Date'},
              {:header => "Rate #{src_currency}#{target_currency}", :format => currency_format},
          ]
      }
  )
  worksheet.set_column(0, 0, 10)
  worksheet.set_column(1, 1, 13)
end

def create_workbook(currency_date, currency_rates, src_currency, target_currency)
  workbook = WriteXLSX.new("fxrates #{src_currency}#{target_currency} #{currency_date}.xlsx")

  data = currency_rates.table_data_currency2rate(currency_date, target_currency)
  create_sheet_currency_rate(workbook, target_currency, currency_date, data)

  data = currency_rates.table_data_date2rate(src_currency, target_currency)
  create_sheet_date_rate(workbook, src_currency, target_currency, data)

  workbook.close
end
