module OpsWorks
  class Layer < Resource
    attr_accessor :id, :name, :shortname, :custom_recipes

    def self.from_collection_response(client, response)
      response.data[:layers].map do |layer|
        hash = layer.to_h
        # Make custom_recipes accessible by string or symbol
        custom_recipes = Thor::CoreExt::HashWithIndifferentAccess.new(
          hash[:custom_recipes]
        )
        new(
          client,
          id: hash[:layer_id],
          name: hash[:name],
          shortname: hash[:shortname],
          custom_recipes: custom_recipes
        )
      end
    end

    def add_custom_recipe(event, recipe)
      return if custom_recipes[event].include?(recipe)

      custom_recipes[event] ||= []
      custom_recipes[event].push recipe
      client.update_layer(
        layer_id: id,
        custom_recipes: custom_recipes
      )
    end

    def remove_custom_recipe(event, recipe)
      return unless custom_recipes[event].include?(recipe)

      custom_recipes[event].delete recipe
      client.update_layer(
        layer_id: id,
        custom_recipes: custom_recipes
      )
    end
  end
end
