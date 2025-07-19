% CMPSC 200 Final Project
% Shlok Chavda, Jake Nardozza
% 4/25/2025
% This project is made to simulate and optimize HVAC energy consumption for a building over one day.

clc;
clear;
close all;

%user inputs
building_area = input('Enter the building area in square meters: ');
insulation_quality = input('Enter insulation quality (1 = poor, 2 = average, 3 = good): ');

%parameters
eff = 3.5; %efficiency rating
set_temp = 22;

%this simulates the outdoor temperatures
hours = 0:23;
outdoor_temp = 10 + 10*sin((hours-8)*pi/12);

%this will build the thermal building characteristics
switch insulation_quality
    case 1
        %bad
        thermal_mass = 0.5;
    case 2
        %average
        thermal_mass = 1.0;
    case 3
        %good
        thermal_mass = 1.5;
    otherwise
        disp('Invalid input, assuming average insulation.');
        thermal_mass = 1.0;
end

%variables
indoor_temp = zeros(size(hours));
indoor_temp(1) = outdoor_temp(1);
energy_used = zeros(size(hours));

%scheduling strategies
strategy = input('Select strategy (0 = always ON, 1 = scheduled): ');


occupancy_start = 8;
occupancy_end = 18;

%simulation
for i = 2:length(hours)
    dt = 1;
    temp_diff = outdoor_temp(i-1) - indoor_temp(i-1);
    indoor_temp(i) = indoor_temp(i-1) + (temp_diff/thermal_mass)*dt;
    
    if strategy == 0
        if abs(indoor_temp(i) - set_temp) > 1
            energy_used(i) = abs(indoor_temp(i) - set_temp) * building_area / eff;
            indoor_temp(i) = set_temp;
        end
    elseif strategy == 1
        if hours(i) >= occupancy_start && hours(i) <= occupancy_end
            if abs(indoor_temp(i) - set_temp) > 1
                energy_used(i) = abs(indoor_temp(i) - set_temp) * building_area / eff;
                indoor_temp(i) = set_temp;
            end
        end
    end
end

%total energy
total_energy = sum(energy_used);
fprintf('Total Energy Used over 24 hours: %.2f kWh\n', total_energy);

%graphs
figure;
plot(hours, outdoor_temp, '-o', 'DisplayName', 'Outdoor Temp');
hold on;
plot(hours, indoor_temp, '-x', 'DisplayName', 'Indoor Temp');
xlabel('Hour');
ylabel('Temperature (°C)');
title('Indoor vs Outdoor Temperature');
legend;
grid on;

figure;
bar(hours, energy_used);
xlabel('Hour');
ylabel('Energy Used (kWh)');
title('Hourly HVAC Energy Consumption');
grid on;


function E = calculate_energy(temp_diff, area, eff)
    E = temp_diff * area / eff;
end