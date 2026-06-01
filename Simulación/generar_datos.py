import os
import csv
import math
import random

def main():
    # Set seed for exact reproducibility
    random.seed(2026)
    
    # Paths
    csv_path = "parametros_banco.csv"
    if not os.path.exists(csv_path):
        csv_path = "../parametros_banco.csv"
        
    if not os.path.exists(csv_path):
        print("Error: parametros_banco.csv not found!")
        return
        
    # Load items
    items = []
    with open(csv_path, mode='r', newline='', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        for row in reader:
            items.append({
                'item': row['item'],
                'dimension': row['dimension'],
                'subtema': row['subtema'],
                'nivel_cognitivo': row['nivel_cognitivo'],
                'a': float(row['a']),
                'b': float(row['b']),
                'c': float(row['c'])
            })
            
    print(f"Loaded {len(items)} items from {csv_path}")
    
    N = 4000
    
    # Cholesky decomposition of Sigma:
    # Sigma = [[1.00, 0.55, 0.50],
    #          [0.55, 1.00, 0.45],
    #          [0.50, 0.45, 1.00]]
    #
    # L = [[1.0, 0.0, 0.0],
    #      [0.55, 0.8351646544521743, 0.0],
    #      [0.50, 0.20953952726359556, 0.8402935201463934]]
    
    L11 = 1.0
    L21 = 0.55
    L22 = 0.8351646544521743
    L31 = 0.50
    L32 = 0.20953952726359556
    L33 = 0.8402935201463934
    
    thetas = []
    responses = []
    
    for j in range(N):
        # Draw 3 independent standard normal variables
        z1 = random.gauss(0.0, 1.0)
        z2 = random.gauss(0.0, 1.0)
        z3 = random.gauss(0.0, 1.0)
        
        # Apply Cholesky
        y1 = z1
        y2 = L21 * z1 + L22 * z2
        y3 = L31 * z1 + L32 * z2 + L33 * z3
        
        thetas.append((y1, y2, y3))
        
        person_resp = []
        for item in items:
            a = item['a']
            b = item['b']
            c = item['c']
            dim = item['dimension']
            
            if dim == 'D1':
                theta = y1
            elif dim == 'D2':
                theta = y2
            elif dim == 'D3':
                theta = y3
            else:
                raise ValueError(f"Unknown dimension {dim}")
                
            # 3PL Logistic formula: P = c + (1-c) / (1 + exp(-a*(theta - b)))
            val = -a * (theta - b)
            # Avoid overflow in exp
            if val > 700:
                prob = c
            elif val < -700:
                prob = 1.0
            else:
                prob = c + (1.0 - c) / (1.0 + math.exp(val))
                
            u = random.random()
            person_resp.append(1 if u < prob else 0)
            
        responses.append(person_resp)
        
    # Create Simulación folder if not exists
    os.makedirs("Simulación", exist_ok=True)
    
    # Save simulated responses
    out_resp_path = os.path.join("Simulación", "datos_simulados.csv")
    with open(out_resp_path, mode='w', newline='', encoding='utf-8') as f:
        writer = csv.writer(f)
        writer.writerow([item['item'] for item in items])
        writer.writerows(responses)
        
    # Save simulated thetas
    out_thetas_path = os.path.join("Simulación", "thetas_simuladas.csv")
    with open(out_thetas_path, mode='w', newline='', encoding='utf-8') as f:
        writer = csv.writer(f)
        writer.writerow(["theta_D1", "theta_D2", "theta_D3"])
        writer.writerows(thetas)
        
    print(f"Successfully simulated responses for {N} respondents and saved to {out_resp_path}")
    print(f"Saved generated thetas to {out_thetas_path}")

if __name__ == "__main__":
    main()
