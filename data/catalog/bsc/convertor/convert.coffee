# Require
_ = require 'underscore'
fs = require 'fs'
path = require 'path'
async = require 'async'

#Consts
main_path = './bsc5.dat'
note_path = './notes'

# Usage
printUsage = ->
        console.log "========================================="
        console.log "Bright Star Catalogue Data Convertor"
        console.log "========================================="
        console.log "Dependencies:"
        console.log "\tunderscore"
        console.log "\tcoffee"
        console.log "\tasync"
        console.log "Usage:"
        console.log "\tcoffee convert template_file_name output_file_name"
        console.log "Required data files:"
        console.log "\tbsc5.dat\t-\tMain BSC catalogue"
        console.log "\tnotes\t\t-\tBSC notes"
        
# Check arguments
is_coffee = process.argv[0].toLowerCase() == 'coffee'
if process.argv.length < 4
        console.error "Error: invalid arguments"
        printUsage()
        process.exit 1

# Check data file
main_exists = fs.existsSync main_path
note_exists = fs.existsSync note_path

console.log "Main catalogue exists...#{main_exists}"
console.log "Note exists...#{note_exists}"

if not (main_exists and note_exists)
        console.error "Error: could not find BSC data files"
        printUsage()
        process.exit 1

# Check template file
temp_path = "./#{process.argv[2]}"
temp_exists = fs.existsSync temp_path

console.log "Template #{temp_path} exists...#{temp_exists}"

if not temp_exists
        console.error "Error: could not find template file '#{temp_path}'"

# Helper
# worker = (line) -> return obj
# callback = (err, data) ->
loadAndParse = (file, worker, callback) ->
        # Load file first
        async.auto
                load: (next) ->
                        fs.readFile file, 'utf8', (err, content) ->
                                if err?
                                        return next? err
                                next? null, content.split '\n'
                parse: ['load', (next, data) ->
                        lines = data.load
                        # Make task
                        tasks = _.map lines, (line) ->
                                return (cb) ->
                                        try
                                                cb null, worker? line
                                        catch err
                                                cb err
                        # Run
                        async.parallel tasks, next
                        ]
                , (err, results) ->
                        if err?
                                return callback err
                        return callback null, results.parse
                  
logBeforeNext = (msg, next) ->
        (err, results) ->
                if err?
                        return next? err
                console.log msg
                next? null, results

parseMainData = (line) ->
        id: parseInt line.substr 0, 4

parseNoteData = (line) ->
        id: parseInt line.substr 0, 5
                        
# Convert work flow
async.auto
        template: (next) ->
                # Open template file
                fs.readFile temp_path,
                        'utf8',
                        logBeforeNext("Template file loaded...", next)
                
        main: (next) ->
                # TODO: parse main catalogue
                loadAndParse main_path,
                        parseMainData,
                        logBeforeNext("Main catalogue loaded...", next)

        note: (next) ->
                # TODO: parse note catalogue
                loadAndParse note_path,
                        parseNoteData,
                        logBeforeNext("Note loaded...", next)
                
        assemble: ['main', 'note', (next, data) ->
                # TODO: assemble main catalogue and notes
                # Sort main data

                asm = _.reduce data.main, ((arr, item) ->
                        arr[item.id] = item
                        return arr), []
                # Insert notes
                asm = _.reduce data.note, ((arr, note) ->
                        id = note.id
                        if not arr[id].notes? then arr[id].notes = []
                        arr[id].notes.push note
                        return arr
                        ), asm
                next? null, asm
                console.log "Data assembled..."
                ]
        generate: ['template', 'assemble', (next, data) ->
                # TODO: generate
                next? null, true
                console.log "Generated..."
                ]
        , (err, results) ->
                if err?
                        console.error "Error: #{err}"
                        process.exit 1
                console.log results.assemble
