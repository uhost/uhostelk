# uhostelk-cookbook

Creates a elkstack server for use with uhost

## Supported Platforms

ubuntu 14.04

## Attributes

<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['uhostelk']['bacon']</tt></td>
    <td>Boolean</td>
    <td>whether to include bacon</td>
    <td><tt>true</tt></td>
  </tr>
</table>

## Usage

### Install

git clone https://github.com/uhost/uhostelk.git

cd uhostelk

berks install

create_crt_key.sh <chef repo path> <server dns name>

If you are using a standard chef repo directory structure where this cookbook is in a directory called cookbooks and at the same level of cookbooks is the data_bags directory then:

create_crt_key.sh ../.. logstash.example.com

berks upload --no-freeze


### uhostelk::default

Include `uhostelk` in your server's `run_list`:

```json
{
  "run_list": [
    "recipe[uhostelk::default]"
  ]
}
```

Include attributes:

```json
{
  "elasticsearch": {
    "discovery": {
      "zen": {
        "minimum_master_nodes": 1
      }
    }
  }
```

### uhostelk::forwarder

Include `uhostelk` in your node's `run_list`:

```json
{
  "run_list": [
    "recipe[uhostelk::forwarder]"
  ]
}
```

Include attributes:

```json
{
  "elasticsearch": {
    "discovery": {
      "zen": {
        "ping": {
          "unicast": {
            "hosts": ["logstash.example.com"]
          }
        }
      }
    }
  }
```

Don't forget to change logstash.example.com to the same dns name for your logstash server

## Testing

Install chefdk and add the embedded/bin to your path

###Install bundler

gem install bundler

###Install from Gemfile

bundle

###Create keys

./create_crt_key.sh default logstash.getuhost.org -z

###Run kitchen

kitchen converage


License & Authors
-----------------
- Author:: Mark Allen (mark@markcallen.com)

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
