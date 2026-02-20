#!/bin/bash
#
# DIY script part 1 (Before Update feeds)
#

# Add OpenClash feed
echo 'src-git openclash https://github.com/vernesong/OpenClash;dev' >>feeds.conf.default

# Add iStore feed
echo 'src-git istore https://github.com/linkease/istore;main' >>feeds.conf.default
echo 'src-git istore_ui https://github.com/linkease/istore-ui;main' >>feeds.conf.default
