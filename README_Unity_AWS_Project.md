# Unity + AWS Cloud Save Integration

A demonstration project integrating a Unity-based game with AWS cloud infrastructure to support runtime cloud saves. All infrastructure is provisioned using Terraform.

---

## 📚 Table of Contents

1. [Project Overview](#project-overview)  
2. [Architecture Diagram](#architecture-diagram)  
3. [Technologies Used](#technologies-used)  
4. [Infrastructure Setup (Terraform)](#infrastructure-setup-terraform)  
5. [Unity Integration](#unity-integration)  
6. [Security Model](#security-model)  
7. [Scalability Considerations](#scalability-considerations)  
8. [Future Improvements](#future-improvements)  
9. [How to Run This Project](#how-to-run-this-project)  
10. [License / Credit / Contact](#license--credit--contact)

---

## Project Overview

A simple but functional demonstration showing how Unity can send and retrieve game save data with AWS services (S3, Lambda, API Gateway, etc.) deployed by Terraform in a highly scalable environment.

## Architecture Diagram

Provide a simple visual showing how Unity communicates with AWS services (S3, Lambda, API Gateway, etc.).

## Technologies Used

- Unity (C#)
- AWS (S3, Lambda, API Gateway, IAM)
- Terraform
- JSON / HTTP
- Github Actions

## Infrastructure Setup (Terraform)

Explain:
- File structure
- Required variables
- Deployment steps
- Destroy instructions

## Unity Integration

Document:
- JSON save structure
- UnityWebRequest setup
- Save/load behavior in the game

## Security Model

Explain:
- IAM roles and policies
- How the API is protected
- Tradeoffs and limitations

## Scalability Considerations

Discuss:
- Optional services like SQS or Cognito
- How this system could grow for multi-user support or scale

## Future Improvements

Outline:
- Features not implemented
- Additional ideas (auth, CI/CD, monitoring, retries)

## How to Run This Project

Step-by-step:
- Prerequisites (AWS CLI, Terraform, Unity version)
- Setup
- Testing
- Cleanup

**SEE CI-CD-Setup.md for instructions on how to run and maintain the pipeline support for this project**


## License / Credit / Contact

https://boto3.amazonaws.com/v1/documentation/api/latest/guide/s3-presigned-urls.html
https://registry.terraform.io/providers/hashicorp/aws/latest/docs
https://docs.aws.amazon.com/apigateway/latest/developerguide/http-api-develop-integrations-lambda.html              # Payload format structure for the http response thru API gateway/lambda