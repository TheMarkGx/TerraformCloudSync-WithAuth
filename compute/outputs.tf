output "api_gateway_endpoint" {
  description = "Public endpoint for the Unity REST API"
  value       = "https://${aws_api_gateway_rest_api.unity_api.id}.execute-api.${var.region}.amazonaws.com/${aws_api_gateway_stage.unity_stage.stage_name}"
}