---
title: Serialize multiple attributes into one column - custom solution
date: 2019-04-23
tags: ["ruby", "rails", "json"]
---

Ever felt you wanted to save multiple entries into one database column in Rails? This is probbly the case when thinking about user preferences or an address field.
Here is a custom implementation how we did it.

READMORE

We wanted to store the address of a customer as JSON in one database column and being able to access stree, zip, city and country easily.
The following implementation gives us JSON serialization for the address field:

```ruby
class Customer < ApplicationRecord
  serialize :address, JSON

end
```

But the separate fields are not easily accessible and we will have issues to hook it up to a form later.
So we decided to write a custom Serializer for the Address:

```ruby
class Address
  include ActiveModel::Model

  ATTRS = [:street, :zip_code, :city, :state, :country]

  attr_accessor(*ATTRS)

  def self.load(data)
    return nil if data.blank?
    attributes = convert_data_to_attributes(data)
    self.new(attributes)
  end

  def self.dump(obj)
    obj.to_json
  end

  def self.convert_data_to_attributes data
    json = JSON.parse(data)
    json.select {|k,_| ATTRS.include? k.to_sym }
  end
  private_class_method :convert_data_to_attributes

end
```

This is quite a bunch. All we need to do now is to specify the attributes listed in ATTRS. The `self.load` and `self.dump` methods are responsible for the serialization process.
Because we use ActiveModel we can also validate e.g. on country by adding these lines to each model:

```ruby
# class Address
    validates :country, presence: true
# end

# class Customer < ApplicationRecord
#  serialize :address, Address

   validates_associated :address
# end
```

If we are using Formtastic or SimpleForm we need to make sure that we add the address object into the form fields. Otherwise the values would not be shown:

```ruby
# formtastic line
  f.inputs name: 'Address', for: [:address, resource.address] do |a|
    a.input :country
  end
```

This is all working ok but there is an even better (and simpler) way to do this with Rails' own methods. How this is done you may read in the next post.