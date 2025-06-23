# Deployment resources (also remember Statefulsets and Daemonsets)
- containers are ephimeral by nature. So we need Scaling and Healing mechanism.
- Deployment resource provides Scaling and Healing functionality.
- Deployment resource create ReplicaSets. Replicasets controls Auto Healing of pods.
- ReplicaSet ensures the number of replicas in deployment resource are running all the time.

### Scaling (Scaling and Healing)
- By default, when a container goes down, it won't come back.
- We need restart policy. Auto healing must be set so it will come back up again.

#### As part of Scaling and healing: During peak time we want:
##### 1) High Availability (HA):
✔ Yes — in production, especially during peak time, you want high availability to avoid downtime. This typically means:
- Running multiple replicas of a pod/container.
- Distributing them across different nodes/zones.

##### 2) Multiple copies of the container:
✔ Correct — you scale out the application (using Deployments or StatefulSets) to handle more traffic.

##### 3) Load balancing:
✔ Kubernetes uses Services (e.g., ClusterIP, LoadBalancer) to route traffic to available pod replicas.
✔ External traffic is often managed by a cloud load balancer (like AWS ALB or NLB), which then distributes traffic to worker nodes → Kubernetes Service → Pods.

```yml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app-deployment
  labels:
    app: my-app
spec:
  replicas: 3  ## Auto Scaling and Auto Healing
  selector:
    matchLabels:
      app: my-app
  template:
    metadata:
      labels:
        app: my-app   ### Used for Service Discovery
    spec:
      serviceAccountName: service-account   ### Service account name
      containers:
      - name: my-app-container  
        image: nginx:latest
        ports:
        - containerPort: 80
        resources:     # ***   resource limits and resource requests
          limits:
            memory: "128Mi"
            cpu: "500m"
          requests:
            memory: "64Mi"
            cpu: "250m"
        readinessProbe:   # ***  Probes
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 5
          periodSeconds: 10
```
### Limits and Requests
- `resource limits and resource requests` for the container in the Kubernetes Deployment. It is used to manage and allocate CPU and memory resources for the container running in the pod.
- Using both CPU and memory requests and limits is a best practice — but if misconfigured, it can cause performance and stability issues. Here's what can go wrong:
- Using both CPU and memory requests/limits is good — but:
- - - ⚠️ Too low → throttling, OOMKills
- - - ⚠️ Too high → poor scheduling, wasted resources
- - - ⚠️ Mismatch → unfair resource use or scheduling issues
---
### Probes

- `readinessProbe` section in the Kubernetes Deployment specifies a readiness check for the container. It ensures that the container is ready to serve traffic before it is added to the Service's load balancer.
###### Explanation:
readinessProbe: A readiness probe determines whether a container is ready to accept requests.
If the probe fails, the pod is marked as not ready, and it will not receive traffic from the Kubernetes Service.

httpGet: Specifies an HTTP GET request to check the readiness of the container.
In this example:
path: /: The probe sends an HTTP GET request to the root path (/) of the container.
port: 80: The probe targets port 80 of the container.

Other Parameters - initialDelaySeconds: 5: The probe waits for 5 seconds after the container starts before performing the first check.
periodSeconds: 10: The probe runs every 10 seconds to check readiness.
- Why is this important?
- - - - Ensures that the container is fully initialized and ready to handle requests before being exposed to traffic.
- - - - Prevents downtime or errors caused by sending traffic to a container that is not ready.
Example Use Case:
For a web application, the readiness probe might check the /health endpoint to ensure the application is running and ready to serve requests.

---

### Other Probes in Kubernetes

#### 1. **Liveness Probe**
- **Purpose**: Checks if a container is still running and healthy.
- **Behavior**: If the probe fails, Kubernetes will restart the container.
- **Use Case**: Detects and resolves issues where the container is stuck or unresponsive.
- **Example**:
```yaml
livenessProbe:
  httpGet:
    path: /health
    port: 8080
  initialDelaySeconds: 10
  periodSeconds: 15
```

#### 2. **Startup Probe**
- **Purpose**: Checks if a container has successfully started.
- **Behavior**: If the probe fails, Kubernetes will restart the container. Once the startup probe succeeds, it disables the liveness probe.
- **Use Case**: Useful for applications that take a long time to initialize.
- **Example**:
```yaml
startupProbe:
  exec:
    command:
    - cat
    - /tmp/healthy
  initialDelaySeconds: 5
  periodSeconds: 10
```

---

### Key Parameters for Probes
- **`initialDelaySeconds`**: Time to wait after the container starts before performing the first probe.
- **`periodSeconds`**: Frequency of probe checks.
- **`timeoutSeconds`**: Maximum time for the probe to complete.
- **`successThreshold`**: Minimum consecutive successes required for the probe to be considered successful.
- **`failureThreshold`**: Number of consecutive failures before the container is restarted or marked as not ready.

---

### Why Are Probes Important?
- **Liveness Probe**: Ensures the container is restarted if it becomes unresponsive.
- **Readiness Probe**: Ensures traffic is only sent to containers that are ready to serve requests.
- **Startup Probe**: Ensures containers are given enough time to initialize before being marked as failed.

Let me know if you need further clarification or additional examples!

