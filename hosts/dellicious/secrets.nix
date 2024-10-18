{ inputs, ... }: {
  imports = [
    inputs.agenix.nixosModules.default
  ];

  age = {
    secrets = {
      secret1 = {
        file = ../../secrets/secret1.age;
        owner = "klowdo";
      };
    };
  };
}
