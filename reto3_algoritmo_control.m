
%% RETO 3 - ALGORITMO DE CONTROL Y CARGAS
% Sistema de Gestion de Energia - SIGE
% Simulacion del balance energetico durante 24 horas

clc;
clear;
close all;

%% 1. CONFIGURACION INICIAL

horas = 1:24;

% Generacion solar (kW) - Datos del Reto 2
solar = [0 0 0 0 0 6 10 15 20 23 24 25 ...
         24 20 16 11 6 2 0 0 0 0 0 0];

% Generacion eolica (kW) - Datos del Reto 2
eolica = [7 5 9 6 11 8 12 7 10 13 6 9 ...
          5 12 8 10 7 10 9 11 6 13 8 10];

% Demanda comunitaria (kW) - Datos del Reto 2
demanda = [3 3 2.5 2.5 3 6 7 8 9 9.5 10 10 ...
           9.5 9 8.5 8 7 15 15 15 15 4 3.5 3];

% Parametros de la bateria
capacidad_bateria = 100; % kWh
SOC = 50;                % Porcentaje inicial

%% 2. INICIALIZACION DE RESULTADOS

generacion_total = zeros(1,24);
balance = zeros(1,24);
SOC_resultado = zeros(1,24);

escuela = strings(1,24);
bombeo = strings(1,24);
alumbrado = strings(1,24);
ruta = strings(1,24);

%% 3. INICIO DE LA SIMULACION

fprintf('\n========================================\n');
fprintf(' SISTEMA SIGE - CONTROL ENERGETICO\n');
fprintf(' SIMULACION DE 24 HORAS\n');
fprintf('========================================\n');

%% 4. CICLO DE CONTROL DE 24 HORAS

for h = 1:24

    % Calcular la generacion hibrida total
    generacion_total(h) = solar(h) + eolica(h);

    % Calcular el balance energetico
    balance(h) = generacion_total(h) - demanda(h);

    % Evaluar el balance y actualizar la bateria
    if generacion_total(h) >= demanda(h)

        % Escenario de superavit
        excedente = generacion_total(h) - demanda(h);

        SOC = SOC + (excedente / capacidad_bateria) * 100;

        % Limitar el SOC al 100 %
        SOC = min(SOC, 100);

        % Todos los servicios permanecen activos
        escuela(h) = "ACTIVO";
        bombeo(h) = "ACTIVO";
        alumbrado(h) = "ACTIVO";
        ruta(h) = "SUPERAVIT";

    else

        % Escenario de deficit
        faltante = demanda(h) - generacion_total(h);

        SOC = SOC - (faltante / capacidad_bateria) * 100;

        % Evitar valores inferiores al 0 %
        SOC = max(SOC, 0);

        % Evaluar los umbrales de desconexion
        if SOC > 40

            % Ruta segura
            escuela(h) = "ACTIVO";
            bombeo(h) = "ACTIVO";
            alumbrado(h) = "ACTIVO";
            ruta(h) = "SEGURA";

        elseif SOC > 20

            % Ruta de alerta
            escuela(h) = "ACTIVO";
            bombeo(h) = "ACTIVO";
            alumbrado(h) = "APAGADO";
            ruta(h) = "ALERTA";

        else

            % Ruta de emergencia
            escuela(h) = "ACTIVO";
            bombeo(h) = "APAGADO";
            alumbrado(h) = "APAGADO";
            ruta(h) = "EMERGENCIA";

        end
    end

    % Guardar el estado de carga de la bateria
    SOC_resultado(h) = SOC;

    %% 5. REPORTE HORARIO EN CONSOLA

    fprintf('\nHORA %02d\n', h);
    fprintf('Generacion solar: %.2f kW\n', solar(h));
    fprintf('Generacion eolica: %.2f kW\n', eolica(h));
    fprintf('Generacion total: %.2f kW\n', generacion_total(h));
    fprintf('Demanda comunitaria: %.2f kW\n', demanda(h));
    fprintf('Balance energetico: %.2f kW\n', balance(h));
    fprintf('SOC de bateria: %.2f %%\n', SOC);
    fprintf('Ruta de operacion: %s\n', char(ruta(h)));
    fprintf('Escuela rural: %s\n', char(escuela(h)));
    fprintf('Bombeo de agua: %s\n', char(bombeo(h)));
    fprintf('Alumbrado publico: %s\n', char(alumbrado(h)));

end

%% 6. TABLA GENERAL DE RESULTADOS

Resultados = table(horas', solar', eolica', ...
    generacion_total', demanda', balance', ...
    SOC_resultado', ruta', escuela', bombeo', alumbrado', ...
    'VariableNames', {'Hora','Solar_kW','Eolica_kW', ...
    'Generacion_kW','Demanda_kW','Balance_kW', ...
    'SOC_porcentaje','Ruta','Escuela','Bombeo','Alumbrado'});

fprintf('\n========================================\n');
fprintf(' RESUMEN GENERAL DE LA SIMULACION\n');
fprintf('========================================\n');

disp(Resultados);

%% 7. GRAFICA DE GENERACION Y DEMANDA

figure;

plot(horas, generacion_total, '-ob', 'LineWidth', 1.5);
hold on;
plot(horas, demanda, '-sr', 'LineWidth', 1.5);

grid on;
xlabel('Hora del dia');
ylabel('Potencia (kW)');
title('Generacion total frente a demanda comunitaria');
legend('Generacion total','Demanda','Location','best');
xticks(1:24);

%% 8. GRAFICA DEL ESTADO DE CARGA DE LA BATERIA

figure;

plot(horas, SOC_resultado, '-og', 'LineWidth', 1.5);
hold on;

yline(40, '--', 'Umbral de alerta');
yline(20, '--', 'Umbral de emergencia');

grid on;
xlabel('Hora del dia');
ylabel('Estado de carga (%)');
title('Evolucion del SOC de la bateria');
ylim([0 100]);
xticks(1:24);

%% 9. FINALIZACION

fprintf('\n========================================\n');
fprintf('SIMULACION FINALIZADA\n');
fprintf('SOC final de la bateria: %.2f %%\n', SOC);
fprintf('Total de horas simuladas: 24\n');
fprintf('========================================\n');
