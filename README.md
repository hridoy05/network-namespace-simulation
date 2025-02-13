# Network Namespaces and Bridges Setup

This project demonstrates how to create and configure network namespaces, virtual Ethernet pairs, and bridges to simulate a simple network environment with a router connecting two namespaces. The setup is automated using a Makefile.

## Table of Contents
- [Network Namespaces and Bridges Setup](#network-namespaces-and-bridges-setup)
  - [Table of Contents](#table-of-contents)
  - [Introduction](#introduction)
  - [Prerequisites](#prerequisites)

---

## Introduction

The goal of this project is to create a virtual network environment using Linux network namespaces and bridges. The setup includes:
- Two network namespaces (`ns1` and `ns2`) representing isolated network environments.
- A router namespace (`router-ns`) acting as a gateway between `ns1` and `ns2`.
- Two bridges (`br0` and `br1`) to connect the namespaces and the router.

This setup allows testing network connectivity between the two namespaces through the router.

---

## Prerequisites

To run this project, you need:
- A Linux-based operating system (e.g., Ubuntu, Debian, CentOS).
- Administrative privileges (sudo access).

---
![network-namespace](https://github.com/user-attachments/assets/68972a1d-8c63-45a9-b9f9-cadf1a31f3cf)


## Setup

The setup is automated using a Makefile. The following steps are performed:
1. **Create Network Bridges**: Two bridges (`br0` and `br1`) are created to connect the namespaces and the router.
2. **Create Network Namespaces**: Three namespaces (`ns1`, `ns2`, and `router-ns`) are created.
3. **Create Virtual Ethernet Pairs**: Virtual Ethernet pairs are created to connect the namespaces to the bridges.
4. **Assign IP Addresses**: IP addresses are assigned to the interfaces within the namespaces.
5. **Enable IP Forwarding**: IP forwarding is enabled in the router namespace to allow traffic between `ns1` and `ns2`.
6. **Set Default Routes**: Default routes are configured in `ns1` and `ns2` to route traffic through the router.
