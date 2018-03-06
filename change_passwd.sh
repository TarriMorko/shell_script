#!/bin/bash
#
#

enc_password="U2FsdGVkX1+ixBaj8zxVyeznV5iNxVUfnczP00Wy694="

echo $enc_password | openssl bf -a -d -pass pass:berkshire | passwd --stdin


