#
# Cookbook Name:: uhostelk
# Recipe:: default
#
# Copyright (C) 2015 YOUR_NAME
#
# All rights reserved - Do Not Redistribute
#

include_recipe "apt"

include_recipe "java::default"
include_recipe "elkstack::default"
