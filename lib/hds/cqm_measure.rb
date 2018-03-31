module HealthDataStandards
   module CQM
    class Measure
      include Mongoid::Document
      field :lower_is_better, type: Boolean
      # this is called in hds Measure but does not resolve correctly
      def data_criteria
        return nil unless self['hqmf_document'] and self['hqmf_document']['data_criteria']
        self['hqmf_document']['data_criteria'].map { |key, val| { key => val } }
      end
      # replaced with the one from cypress for compatibility with their baroque processing
      # def data_criteria
      #   self.hqmf_document['data_criteria']
      # end
      # def population_criteria
      #   self.hqmf_document['population_criteria']
      # end
      # doesn't actually match the damn data in cqm/measure
      # def all_data_criteria
      #   return @crit if @crit
      #   @crit = []
      #   self.data_criteria.each do |k, v|
      #       @crit << HQMF::DataCriteria.from_json(k,v)
      #   end
      #   @crit
      # end

    end
  end
end
