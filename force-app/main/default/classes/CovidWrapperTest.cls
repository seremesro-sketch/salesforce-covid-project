@isTest
private class CovidWrapperTest {

    @isTest
    static void testWrapperCoverage() {

        // Crear instancia
        CovidWrapper wrapper = new CovidWrapper();

        // Solo asignar si existen campos públicos
        wrapper.states = 56;
        wrapper.positive = 100;
        wrapper.death = 5;
        wrapper.hospitalizedCurrently = 80;

        // Validaciones
        System.assertEquals(56, wrapper.states);
        System.assertEquals(100, wrapper.positive);
        System.assertEquals(5, wrapper.death);
        System.assertEquals(80, wrapper.hospitalizedCurrently);
    }
}