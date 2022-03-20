#!/bin/bash

rm *.gem
gem build omniauth-cz-shop-platforms.gemspec
gem push omniauth-cz-shop-platforms-*.gem
