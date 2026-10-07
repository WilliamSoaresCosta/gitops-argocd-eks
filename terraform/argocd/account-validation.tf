# Trava de segurança: não roda na conta AWS errada
check "aws_account_matches_environment" {
  assert {
    condition     = data.aws_caller_identity.current.account_id == var.expected_account_id
    error_message = "Conta AWS incorreta para este ambiente. Esperado ${var.expected_account_id}, obtido ${data.aws_caller_identity.current.account_id}."
  }
}
