#!/bin/bash
echo "============================================================"
echo "  IT 3012 Integration Hub - Starting All Systems"
echo "============================================================"

cd testpoint_app && python app.py &
echo "[1/4] TestPoint started on port 5000"
sleep 2

cd ../voxify_app && python app.py &
echo "[2/4] Voxify started on port 5001"
sleep 2

cd ../newchange_app && python app.py &
echo "[3/4] NewChange started on port 5002"
sleep 2

cd ../hub && pip install flask requests -q && python app.py &
echo "[4/4] Integration Hub started on port 5003"

echo ""
echo "Open: http://localhost:5003"
wait
