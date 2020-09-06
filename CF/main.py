# Function to return the following:
# Current Region
# Current Time
# Requester Information
from flask import Flask, render_template, flash, request, redirect, jsonify, Response
import os
from datetime import datetime


def MyApp(request):
    # Main Function
    reply = {}
    reply["Region"] = os.environ['FUNCTION_REGION']
    reply["Name"] = os.environ['FUNCTION_NAME']
    reply["TimeStamp"] = datetime.now()
    
    return jsonify(reply)
