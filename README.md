# Homelab Configuration Files

This repository contains the configuration for my homelab. It is in theory possible to use this for your own homelab, though some tweaking maybe necessary, and some features are dependant on specific hardware.

## Ansible

No longer used, but this was ansible scripts to deploy the cluster initiall. I've had to make a few changes, so they are no longer up to date. May still work though.

## Argocd

Kubernetes Manifest Files loaded by argocd. Argocd initially looks at argocd/argocd/install for bootstrapping the cluster. This  then builds out app definitions which load everything else.

![App Diagram](./diagram/applications.svg)

## Charts

Helm charts used for deploying some apps.

### docker-app

Generic chart for deploying a docker app that doesn't already have a chart. Pass in the image and a few other details and it should deploy all required resources for the app.

### external-services

Small chart to deploy resources necessary for proxying connections to apps hosted outside the cluster.

## Diagram

Code to generate diagrams, using D2.

## k6

k6 scripts to load test applications.

## Scripts

varied, but generally useful scripts for the cluster.

## Terraform

Terraform code to deploy infrastructure. Deploys DNS records locally on firewall, and in cloudflare. Also deploys the infrastructure hosted in oracle cloud.

![Network Diagram](./diagram/network.svg)


![Hardware Diagram](./diagram/hardware.svg)

