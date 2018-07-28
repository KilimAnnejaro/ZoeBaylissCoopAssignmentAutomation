
using Mux
using HTTP
using JuMP, Clp

@app test = (
Mux.defaults,
page(respond(kitchenDuties($(req[:params][:web_address])))),
Mux.notfound())

serve(test)
#This script becomes a function, call function, get result, return result (respond(result) not respond(hello world))
#need to upload CSV from HTML
#alternative: pass in web address to the HTML call, change this --|U
addr = "https://raw.githubusercontent.com/KilimAnnejaro/ZoeBaylissCoopAssignmentAutomation/master/Test.csv"
function kitchenDuties(addr)
    res = HTTP.get(addr)
    raw = readcsv(res.body);
    print("hello")
    names = [1:7]
    preferences = zeros(14,7)
    x = raw[1,:]
    println(x)
    for i in 1:14
        for j in 1:7
            preferences[i,j] = raw[i+1,j+1]
        end
    end
    println("hello")
    println(preferences[1,1])
    println(preferences[14,7])


    m = Model(solver=ClpSolver())
    @variable(m, u[1:14,1:7])

    for i in 1:14
        for j in 1:7
            @constraint(m,u[i,j]<=1)
            @constraint(m,u[i,j]>=0)
        end
        @constraint(m,sum(u[i,k] for k in 1:7)==1)
    end
    for j in 1:7
        @constraint(m,sum(u[h,j] for h in 1:14)==2)
    end
    @objective(m, Min, sum(u[i,j].*preferences[i,j] for i in 1:14,j in 1:7) )

    status = solve(m)

    println(status)
    println()
    return (abs(getvalue(u)))

end
println(kitchenDuties(addr))
"""    for i in 1:14
        for j in 1:7
            print(abs(getvalue(u[i,j])))
            print(" ")
        end
        println()
end"""

using JuMP, Clp

m = Model(solver=ClpSolver())
@variable(m, u[1:14,1:7])
#@variable(m, 1 <= q <= 4 )
for i in 1:14
    for j in 1:7
        @constraint(m,u[i,j]<=1)
        @constraint(m,u[i,j]>=0)
    end
    @constraint(m,sum(u[i,k] for k in 1:7)==1)
end
for j in 1:7
    @constraint(m,sum(u[h,j] for h in 1:14)==2)
end
@objective(m, Min, sum(u[i,j].*preferences[i,j] for i in 1:14,j in 1:7) )

status = solve(m)

#println(m)
println(status)
println()
for i in 1:14
    for j in 1:7
        print(abs(getvalue(u[i,j])))
        print(" ")
    end
    println()
end
#println("objective = ", getobjectivevalue(m) )

Pkg.add("HTTP")

#@Pkg.build("HTTP")
