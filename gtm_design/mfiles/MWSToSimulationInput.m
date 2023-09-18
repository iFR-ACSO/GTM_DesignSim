function in = MWSToSimulationInput(MWSinit)
    
    in = Simulink.SimulationInput('gtm_design');   

    % Get the fieldnames of the structure
    fieldNames = fieldnames(MWSinit);
    
    % for fn = fieldnames(MWSinit)
    % 
    %     fieldValue = MWSinit.{fn};
    % 
    %     in = in.setVariable({fn},fieldValue,'Workspace','gtm_design'); 
    % end


    for i = 1:numel(fieldNames)
        fieldName = fieldNames{i};
        fieldValue = MWSinit.(fieldName);
        
        in = in.setVariable(fieldName,fieldValue,'Workspace','gtm_design');             
    end
end