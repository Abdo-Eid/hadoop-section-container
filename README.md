# Hadoop Lab Setup (Docker-Based)

This repo provides an easy way to set up a Hadoop environment using Docker, designed for Big Data course labs. It avoids complicated local installations and lets you get started with minimal setup.

---

## 🚀 How to Build the Docker Image

By default, the Dockerfile **downloads Hadoop** from the internet.  
If you already have the `hadoop-3.4.1.tar.gz` file locally, follow these steps:

### ✅ Option 1: Using a Local Hadoop Binary (Preferred if You Have It)

1. Place `hadoop-3.4.1.tar.gz` in the project directory.
2. In the `Dockerfile`:
   - **Uncomment**:
     ```dockerfile
     COPY hadoop-3.4.1.tar.gz /tmp/hadoop.tar.gz
     ```
   - **Comment out** the line that uses `wget`.

### 🔧 Build the Image

```bash
docker build -t big-data-section .
````

---

## 🐳 Running the Container

```bash
docker run -it --name section-container -p 9870:9870 -p 8088:8088 -p 9000:9000 big-data-section
```

This exposes the necessary ports for the Hadoop Web UI and services.

---

## 📁 Copying Section Material Into the Container

Assuming you have the material in a local folder:

```bash
docker cp /full/path/to/sections_data section-container:/home/hadoop/
```

---

## 🧩 Managing the Container

### 🔄 Reattach to a Running Container

```bash
docker exec -it section-container bash
```

### 🛑 Stop/Kill the Container

```bash
docker stop section-container
```

### ▶️ Start It Again

```bash
docker start -ai section-container
```

---

## 💾 Sharing the Image (No Rebuild Needed)

### 🔒 Save the Image to a File

```bash
docker save -o big-data-section.tar big-data-section
```

Share the `big-data-section.tar` file via USB, Google Drive, etc.

### 📥 Load the Image on Another Machine

```bash
docker load -i big-data-section.tar
```

Then run it normally:

```bash
docker run -it --name section-container -p 9870:9870 -p 8088:8088 -p 9000:9000 big-data-section
```

---

## 📌 Notes

* The first build may take some time.
* Make sure Docker is installed and running before starting.
* If you're using WSL on Windows, use Linux-style paths and check port availability.

---

## 🔍 Quick Summary

* Your **image** name is: `big-data-section`
* Your **container** name is: `section-container`
* Your **hostname** inside container is: `hadoop-node`

### When the container is running:

* Visit **NameNode Web UI** → `http://localhost:9870`
* Visit **YARN ResourceManager UI** → `http://localhost:8088`
* SSH into the container if needed on port 22
* You can run Python-based MapReduce with `mrjob`:

  ```bash
  python mrjob_script.py input_file
  ```

---

Made for Big Data course labs – by students, for students 👨‍🎓👩‍🎓

> By Abdulahmed Samy