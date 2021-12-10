import argparse

parser = argparse.ArgumentParser(description="A Simple Calculator")
parser.add_argument("-op", help="Arithmatic Operation", required=True, dest="op", metavar="operation")
parser.add_argument("num", help="Numbers as an input ", type=float, nargs="*", metavar="numbers")
args = parser.parse_args()
n1 = args.num


# This function adds two numbers
def addition(a):
    sum1 = 0
    for i in a:
        sum1 += i
    return sum1


# This function subtracts two numbers
def subtraction(b):
    sub = b[0]
    for j in range(1, len(b)):
        sub -= b[j]
    return sub


# This function multiplies two numbers
def multiplication(c):
    multiply = c[0]
    for j in range(1, len(c)):
        multiply *= c[j]
    return multiply


# This function divides of numbers
def divide(d):
    first = d[0]
    for k in range(1, len(d)):
        first /= d[k]
    return first


# This function used to perform modulator operator
def modulator(e):
    mod = e[0]
    for listiterator in range(1, len(e)):
        mod %= e[listiterator]
    return mod


def exponential(f):
    expo = f[0]
    for listiterator in range(1, len(f)):
        expo **= f[listiterator]
    return expo


def floor(g):
    floor_value = g[0]
    for listiterator in range(1, len(g)):
        floor_value //= g[listiterator]
    return floor_value


user_opt = args.op

match user_opt:
    case "add":
        print("addition result of the given values: ", addition(n1))

    case "sub":
        print("subtaction result of the given values: ", subtraction(n1))

    case "mul":
        print("multiplication result of the given values: ", multiplication(n1))

    case "div":
        print("division result of the given values: ", divide(n1))

    case "mod":
        print("modulo division result of the given values: ", modulator(n1))

    case "exp":
        print("exponential result of the given values: ", exponential(n1))

    case "floor":
        print("floor division result of the given values: ", floor(n1))

    case _:
        print(
            "invalid input, the available operations are: \n [option -operation]  \n addition -add \n subtraction "
            "-sub \n "
            "multiplication -mul \n division -div \n modulo division -mod \n exponential -expo \n floor value -floor")
