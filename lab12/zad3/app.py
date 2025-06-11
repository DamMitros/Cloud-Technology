import platform

system = platform.system()

if system == "Windows":
  print("Witaj na systemie Windows!")
elif system == "Linux":
  print("Witaj na systemie Linux!")
else:
  print(f"Witaj na nieznanym systemie: {system}")
