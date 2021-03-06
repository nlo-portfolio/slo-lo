![Slo-Lo](https://raw.githubusercontent.com/nlo-portfolio/nlo-portfolio.github.io/master/style/images/programs/slo-lo.png "Slo-Lo")

## Description ##

Slo-Lo is a quick and simple implementation of the Slowloris HTTP DoS attack, which attempts to subdue a webserver by creating a multitude of open sockets without completing the requests. This technique is particularly effective against threaded servers such as Apache.<br>

## Dependencies ##

Ubuntu<br>
Ruby v3<br>
Tests require `curl`, `wget`.<br>
\* All required components are included in the provided Docker image.

## Usage ##

Fill out the configuration file.<br>
<br>
Ubuntu:

```
ruby slo_lo.rb
ruby test/run_tests.rb --verbose    # (from the project root directory)
```

Docker:

```
docker-compose build
docker-compose run <slo-lo | test>
```
