import nextflow.io.ValueObject

@ValueObject // serialize the class and cache it
class Dog {
    String name // string representation of the Dog object in Java
    Boolean isHungry = true
}
