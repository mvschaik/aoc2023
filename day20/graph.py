
print("strict digraph {")
with open("input.txt") as f:
    for line in f:
        parts = line.split(" -> ")
        print("%s -> { %s };" % (parts[0].lstrip("%&"), parts[1].strip()))
print("}")
