-- Function to calculate square root
function calculateSquareRoot(number)
    return math.sqrt(number)
end

-- Function to calculate sine
function calculateSine(angle)
    return math.sin(math.rad(angle))
end

-- Function to calculate cosine
function calculateCosine(angle)
    return math.cos(math.rad(angle))
end

-- Function to calculate logarithm
function calculateLogarithm(number, base)
    return math.log(number, base)
end

-- Function to calculate factorial
function calculateFactorial(number)
    local result = 1
    for i = 2, number do
        result = result * i
    end
    return result
end

-- Function to calculate circle area
function calculateCircleArea(radius)
    return math.pi * radius * radius
end

-- Function to calculate triangle area
function calculateTriangleArea(base, height)
    return 0.5 * base * height
end

-- Function to calculate square area
function calculateSquareArea(side)
    return side * side
end

-- Function to calculate rectangle area
function calculateRectangleArea(length, width)
    return length * width
end

-- Function to calculate equilateral triangle area
function calculateEquilateralTriangleArea(side)
    return (math.sqrt(3) / 4) * side * side
end

-- Function to add two numbers
function addNumbers(a, b)
    return a + b
end

-- Function to subtract two numbers
function subtractNumbers(a, b)
    return a - b
end

-- Function to multiply two numbers
function multiplyNumbers(a, b)
    return a * b
end

-- Function to divide two numbers
function divideNumbers(a, b)
    if b ~= 0 then
        return a / b
    else
        return "Error: Division by zero"
    end
end

-- Function to display a paginated menu
function displayMenu(title, options)
    local page = 1
    local optionsPerPage = 5
    local totalOptions = #options
    local totalPages = math.ceil(totalOptions / optionsPerPage)

    repeat
        term.clear()
        term.setCursorPos(1, 1)
        print("╔═════════════════════════════════════╗")
        print("║          " .. title .. "          ║")
        print("╠═════════════════════════════════════╣")

        local start = (page - 1) * optionsPerPage + 1
        local finish = math.min(start + optionsPerPage - 1, totalOptions)

        for i = start, finish do
            print("║ " .. i .. ". " .. options[i])
        end

        print("║ N. Next Page                           ║")
        print("║ P. Previous Page                       ║")
        print("║ 0. Exit                                ║")
        print("╚═════════════════════════════════════╝")

        write("Option: ")
        local input = read()
        local option = tonumber(input)

        if option == nil then
            if input:upper() == "N" and page < totalPages then
                page = page + 1
            elseif input:upper() == "P" and page > 1 then
                page = page - 1
            end
        elseif option >= 1 and option <= totalOptions then
            return option
        elseif option == 0 then
            return option
        end
    until false
end

-- Main program
repeat
    local option = displayMenu("Scientific Calculator", {
        "Calculate Square Root",
        "Calculate Sine",
        "Calculate Cosine",
        "Calculate Logarithm",
        "Calculate Factorial",
        "Calculate Circle Area",
        "Calculate Triangle Area",
        "Calculate Square Area",
        "Calculate Rectangle Area",
        "Calculate Equilateral Triangle Area",
        "Add Numbers",
        "Subtract Numbers",
        "Multiply Numbers",
        "Divide Numbers"
    })

    if option == 1 then
        -- Calculate Square Root
        print("Enter a number: ")
        local number = tonumber(read())
        local result = calculateSquareRoot(number)
        print("Result: " .. result)
        os.pullEvent("key")
    elseif option == 2 then
        -- Calculate Sine
        print("Enter an angle: ")
        local angle = tonumber(read())
        local result = calculateSine(angle)
        print("Result: " .. result)
        os.pullEvent("key")
    elseif option == 3 then
        -- Calculate Cosine
        print("Enter an angle: ")
        local angle = tonumber(read())
        local result = calculateCosine(angle)
        print("Result: " .. result)
        os.pullEvent("key")
    elseif option == 4 then
        -- Calculate Logarithm
        print("Enter a number: ")
        local number = tonumber(read())
        print("Enter the base: ")
        local base = tonumber(read())
        local result = calculateLogarithm(number, base)
        print("Result: " .. result)
        os.pullEvent("key")
    elseif option == 5 then
        -- Calculate Factorial
        print("Enter a number: ")
        local number = tonumber(read())
        local result = calculateFactorial(number)
        print("Result: " .. result)
        os.pullEvent("key")
    elseif option == 6 then
        -- Calculate Circle Area
        print("Enter the radius: ")
        local radius = tonumber(read())
        local result = calculateCircleArea(radius)
        print("Result: " .. result)
        os.pullEvent("key")
    elseif option == 7 then
        -- Calculate Triangle Area
        print("Enter the base: ")
        local base = tonumber(read())
        print("Enter the height: ")
        local height = tonumber(read())
        local result = calculateTriangleArea(base, height)
        print("Result: " .. result)
        os.pullEvent("key")
    elseif option == 8 then
        -- Calculate Square Area
        print("Enter the side length: ")
        local side = tonumber(read())
        local result = calculateSquareArea(side)
        print("Result: " .. result)
        os.pullEvent("key")
    elseif option == 9 then
        -- Calculate Rectangle Area
        print("Enter the length: ")
        local length = tonumber(read())
        print("Enter the width: ")
        local width = tonumber(read())
        local result = calculateRectangleArea(length, width)
        print("Result: " .. result)
        os.pullEvent("key")
    elseif option == 10 then
        -- Calculate Equilateral Triangle Area
        print("Enter the side length: ")
        local side = tonumber(read())
        local result = calculateEquilateralTriangleArea(side)
        print("Result: " .. result)
        os.pullEvent("key")
    elseif option == 11 then
        -- Add Numbers
        print("Enter the first number: ")
        local num1 = tonumber(read())
        print("Enter the second number: ")
        local num2 = tonumber(read())
        local result = addNumbers(num1, num2)
        print("Result: " .. result)
        os.pullEvent("key")
    elseif option == 12 then
        -- Subtract Numbers
        print("Enter the first number: ")
        local num1 = tonumber(read())
        print("Enter the second number: ")
        local num2 = tonumber(read())
        local result = subtractNumbers(num1, num2)
        print("Result: " .. result)
        os.pullEvent("key")
    elseif option == 13 then
        -- Multiply Numbers
        print("Enter the first number: ")
        local num1 = tonumber(read())
        print("Enter the second number: ")
        local num2 = tonumber(read())
        local result = multiplyNumbers(num1, num2)
        print("Result: " .. result)
        os.pullEvent("key")
    elseif option == 14 then
        -- Divide Numbers
        print("Enter the first number: ")
        local num1 = tonumber(read())
        print("Enter the second number: ")
        local num2 = tonumber(read())
        local result = divideNumbers(num1, num2)
        print("Result: " .. result)
        os.pullEvent("key")
    elseif option == 0 then
        print("Exiting...")
        os.pullEvent("key")
    else
        print("Invalid option. Please try again.")
        os.pullEvent("key")
    end

    print("") -- Blank line for clarity

    print("Press any key to continue...")
    os.pullEvent("key")
until option == 0
