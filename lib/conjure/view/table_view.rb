module Conjure
  module View
    class TableView
      def initialize(data)
        @data = data
        calculate_widths
      end

      def render
        rows = [@width.map{|col, width| pad_to_width(col, width)}.join(column_separator)]
        rows += @data.map do |row|
          @width.map{|col, width| pad_to_width(row[col], width)}.join(column_separator)
        end
        rows.join("\n")
      end

      private

      def column_separator
        "  "
      end

      def pad_to_width(string, width)
        string.to_s + " "*(width - string.to_s.length)
      end

      def calculate_widths
        @width = {}
        @data.each do |row|
          row.each_pair do |key, value|
            @width[key] ||= key.to_s.length
            @width[key] = [@width[key], value.to_s.length].max
          end
        end
      end
    end
  end
end
