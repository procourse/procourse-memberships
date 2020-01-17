Fabricator(:level) do
  level PluginStore.set("procourse_memberships", "levels", {
      id: 1,
      name: "Dummy Level",
      enabled: true,
      group: "test_group",
      trust_level: 0,
      initial_payment: 10,
      recurring: false,
      description_raw: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam tempor justo turpis, id bibendum est placerat ac. Fusce mollis felis in mauris molestie lobortis. Nunc elementum fermentum dui, at congue ex auctor sit amet. Maecenas enim mauris, iaculis in ligula eu, commodo sollicitudin purus. Fusce ultricies nulla lorem, in rutrum orci semper nec. Etiam eleifend diam non ante interdum, ut laoreet ipsum fringilla. Integer venenatis dignissim malesuada." ,
      description_cooked: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam tempor justo turpis, id bibendum est placerat ac. Fusce mollis felis in mauris molestie lobortis. Nunc elementum fermentum dui, at congue ex auctor sit amet. Maecenas enim mauris, iaculis in ligula eu, commodo sollicitudin purus. Fusce ultricies nulla lorem, in rutrum orci semper nec. Etiam eleifend diam non ante interdum, ut laoreet ipsum fringilla. Integer venenatis dignissim malesuada.",
      welcome_message: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam tempor justo turpis, id bibendum est placerat ac. Fusce mollis felis in mauris molestie lobortis. Nunc elementum fermentum dui, at congue ex auctor sit amet. Maecenas enim mauris, iaculis in ligula eu, commodo sollicitudin purus. Fusce ultricies nulla lorem, in rutrum orci semper nec. Etiam eleifend diam non ante interdum, ut laoreet ipsum fringilla. Integer venenatis dignissim malesuada."
  })
end

Fabricator(:recurring_level) do
    level PluginStore.set("procourse_memberships", "levels", {
        id: 2,
        name: "Dummy Recurring Level",
        enabled: true,
        group: "test_group",
        trust_level: 0,
        initial_payment: 10,
        recurring: true,
        recurring_payment: 10,
        recurring_payment_period: 30,
        description_raw: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam tempor justo turpis, id bibendum est placerat ac. Fusce mollis felis in mauris molestie lobortis. Nunc elementum fermentum dui, at congue ex auctor sit amet. Maecenas enim mauris, iaculis in ligula eu, commodo sollicitudin purus. Fusce ultricies nulla lorem, in rutrum orci semper nec. Etiam eleifend diam non ante interdum, ut laoreet ipsum fringilla. Integer venenatis dignissim malesuada." ,
        description_cooked: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam tempor justo turpis, id bibendum est placerat ac. Fusce mollis felis in mauris molestie lobortis. Nunc elementum fermentum dui, at congue ex auctor sit amet. Maecenas enim mauris, iaculis in ligula eu, commodo sollicitudin purus. Fusce ultricies nulla lorem, in rutrum orci semper nec. Etiam eleifend diam non ante interdum, ut laoreet ipsum fringilla. Integer venenatis dignissim malesuada.",
        welcome_message: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam tempor justo turpis, id bibendum est placerat ac. Fusce mollis felis in mauris molestie lobortis. Nunc elementum fermentum dui, at congue ex auctor sit amet. Maecenas enim mauris, iaculis in ligula eu, commodo sollicitudin purus. Fusce ultricies nulla lorem, in rutrum orci semper nec. Etiam eleifend diam non ante interdum, ut laoreet ipsum fringilla. Integer venenatis dignissim malesuada."
    })
  end