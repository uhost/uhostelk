# uhostelk-cookbook

TODO: Enter the cookbook description here.

## Supported Platforms

TODO: List your supported platforms.

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

###Run kitchen

kitchen converage


## License and Authors

Author:: YOUR_NAME (<YOUR_EMAIL>)
