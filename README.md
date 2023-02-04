# Tootaloo Backend Setup

- Install virtual environment wrapper:

    - Windows: ```pip install virtualenvwrapper-win```
    - Mac OS: ```pip install virtualenvwrapper```

- Create virtual environment (inside of tootalooBackend Directory):
  - Windows: ```mkvirtualenv .venv```
  - Mac OS: ```virtualenv .venv```

- Activate the virtual environment:
    - Windows: ```workon .venv```
    - Mac OS: ```source .venv/bin/activate```

---

- Install the packages needed in your virtual environment:
  - ```pip install -r requirements.txt```

- Whenever you install a package with pip, update requirements.txt:
  - ```pip freeze > requirements.txt``` 
  - Inside the directory where requirements.txt exists. Make sure your virtual environment is activated when you perform this.

---
- Start the server using the ```python3 manage.py runserver``` command.

- To deactivate the virtual environment, just type the command `deactivate`.
