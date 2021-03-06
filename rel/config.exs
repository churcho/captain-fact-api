# Import all plugins from `rel/plugins`
# They can then be used by adding `plugin MyPlugin` to
# either an environment, or release definition, where
# `MyPlugin` is the name of the plugin module.
Path.join(["rel", "plugins", "*.exs"])
|> Path.wildcard()
|> Enum.map(&Code.eval_file(&1))

use Mix.Releases.Config,
    default_release: :captain_fact,
    default_environment: Mix.env()

# Environments

environment :dev do
  set dev_mode: false # Disable symlinks that breaks docker dev image release. Uncomment to debug build
  set include_erts: false
  set include_src: false
  set cookie: :"MfqNgHUln;rEBpHUv^)@~8.b1wJ)>0W3<drs>ZRk0(S>qMU):<JtlEIiwR|/Oc>R"
end

environment :prod do
  set dev_mode: false
  set include_erts: false
  set include_src: false
  set cookie: :"86@K5T~*`8U71EA5oGP?zEy~`b]@~CS{I|]OJn6EW|>V2A]r|(w[LYl69!;;[n$P"
end

# Releases

release :captain_fact do
  set version: current_version(:captain_fact)
  set applications: [:captain_fact]
  set post_start_hook: "rel/hooks/post_start.sh"
  set commands: [
    "migrate": "rel/commands/migrate.sh",
    "seed": "rel/commands/seed.sh",
    "seed_politicians": "rel/commands/seed_politicians.sh"
  ]
end

release :cf_graphql do
  set version: current_version(:cf_graphql)
  set applications: [:cf_graphql]
  set commands: ["migrate": "rel/commands/migrate.sh"]
end

release :cf_atom_feed do
  set version: current_version(:cf_atom_feed)
  set applications: [:cf_atom_feed]
end

release :cf_opengraph do
  set version: current_version(:cf_opengraph)
  set applications: [:cf_opengraph]
  set code_paths: ["apps/opengraph"]
end
