require "multi_forkr"
MultiForkr.new({
  Listeners::EmployerDigestDropListener => 1,
  Listeners::EmployerLegacyDigestListener => 1,
  Listeners::EmployerLegacyDigestTransformer => 1,
  Listeners::EmployerDigestPaymentProcessorListener => 1
}).run
