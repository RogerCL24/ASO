#!/bin/bash

ps -eo pid,user,time,comm --sort=-time | head -n 11

